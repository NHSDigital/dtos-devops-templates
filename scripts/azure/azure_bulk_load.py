"""
Async bulk publisher for Azure Service Bus Topics.
- Streams N JSON records (from stdin, CSV, or synthetic) to a topic.
- Uses batching + asyncio concurrency for maximum throughput.
"""

import argparse, asyncio, csv, json, os, sys, time
from itertools import islice
from typing import AsyncIterator, Dict
import uuid
import copy

from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage

# ---------- Helpers ---------------------------------------------------------

async def json_row_source(path: str | None, rows: int) -> AsyncIterator[Dict]:
    """Generate a stream of dict rows. Use file as a base template, repeating and modifying as needed."""
    if path:
        ext = os.path.splitext(path)[1].lower()
        open_fn = open if path != "-" else (lambda *_: sys.stdin)
        with open_fn(path, "r", encoding="utf-8") as fh:
            if ext == ".csv":
                templates = list(csv.DictReader(fh))
            else:  # JSON Lines
                templates = [json.loads(line) for line in fh]

        total_templates = len(templates)
        if total_templates == 0:
            raise ValueError("Input file is empty")

        for i in range(rows):
            base = copy.deepcopy(templates[i % total_templates])
            # Inject or override fields to make each row unique
            base["synthetic_id"] = i
            base["uuid"] = str(uuid.uuid4())
            if "id" in base:
                base["id"] = f"{base['id']}_{i}"
            yield base
    else:
        # Default synthetic data if no file given
        for i in range(rows):
            yield {"id": i, "payload": f"row-{i}"}

async def send_worker(
    client: ServiceBusClient,
    topic: str,
    row_iter: AsyncIterator[Dict],
    batch_size: int,
    worker_id: int,
):
    sender = client.get_topic_sender(topic_name=topic)
    async with sender:
        batch = await sender.create_message_batch()
        async for row in row_iter:
            msg = ServiceBusMessage(json.dumps(row))
            try:
                batch.add_message(msg)
            except ValueError:               # batch is full
                await sender.send_messages(batch)
                batch = await sender.create_message_batch()
                batch.add_message(msg)
            if batch_size and batch.count >= batch_size:
                await sender.send_messages(batch)
                batch = await sender.create_message_batch()
        if len(batch) > 0:
            await sender.send_messages(batch)
    print(f"[worker {worker_id}] complete")

# ---------- Main -----------------------------------------------------------

async def main_async(args):
    conn_str = os.getenv("SERVICE_BUS_CONNECTION_STR")
    if not conn_str:
        raise RuntimeError("Set SERVICE_BUS_CONNECTION_STR env-var")

    client = ServiceBusClient.from_connection_string(
        conn_str,
        logging_enable=False,  # turn on for diagnostics
    )

    # One async generator shared by all workers
    row_gen = json_row_source(args.file, args.rows)
    row_iterators = [row_gen] * args.concurrency

    t0 = time.perf_counter()
    async with client:
        await asyncio.gather(
            *[
                send_worker(client, args.topic, it, args.batch, idx)
                for idx, it in enumerate(row_iterators)
            ]
        )
    elapsed = time.perf_counter() - t0
    print(f"✅ Sent {args.rows:,} rows in {elapsed:,.1f}s "
        f"({args.rows/elapsed:,.0f} msg/s)")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Bulk Service Bus publisher")
    parser.add_argument("--topic", required=True, help="Service Bus topic name")
    parser.add_argument("--rows", type=int, default=2_000_000,
                        help="Number of rows to publish (default 2 M)")
    parser.add_argument("--file", help="CSV or JSONL input file (omit for synthetic)")
    parser.add_argument("--batch", type=int, default=0,
                        help="Force send after N messages added to batch "
                            "(0 = until size limit)")
    parser.add_argument("--concurrency", type=int, default=8,
                        help="Parallel async senders")
    asyncio.run(main_async(parser.parse_args()))
