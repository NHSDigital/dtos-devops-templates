function showSection(id) {
  // window.scrollTo({ top: 0, behavior: 'smooth' });

  const sections = document.querySelectorAll('.content-section');
  sections.forEach( (sec) => {
    // @ts-ignore
    sec.style.display = 'none';
    // @ts-ignore
    sec.style.height = '0';
    // @ts-ignore
    sec.style.overflow = 'hidden';
  });

  const selected = document.getElementById(id);
  if (selected) {
    selected.style.display = 'block';
    selected.style.height = 'auto';
    selected.style.overflow = 'visible'; // NOT 'none'
  }

  // Remove "selected" class from all links
  let links = document.querySelectorAll('.sidebar a');
  links.forEach(link => {
    const href = link.getAttribute('href');
    // @ts-ignore
    if (href && href.includes(id))
      link.classList.add('selected');
    else
      link.classList.remove('selected');
  });
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.collapsible-header').forEach(header => {
    header.addEventListener('click', () => {
      const parent = header.parentElement;
      parent.classList.toggle('open');
    });
  });
  showSection('summary');
});

document.addEventListener("DOMContentLoaded", () => {
  const tooltip = document.createElement("div");
  tooltip.className = "tooltip-float";
  document.body.appendChild(tooltip);

  document.querySelectorAll(".has-tooltip").forEach(cell => {
    const inner = cell.querySelector(".tooltip-text");
    if (!inner) return;

    cell.addEventListener("mouseenter", () => {
      tooltip.innerHTML = inner.innerHTML;
      tooltip.style.opacity = "1";
      tooltip.style.display = "block";
      tooltip.style.visibility = "visible";

      const rect = cell.getBoundingClientRect();
      const scrollY = window.scrollY || document.documentElement.scrollTop;
      const scrollX = window.scrollX || document.documentElement.scrollLeft;

      tooltip.style.left = `${scrollX + rect.left + rect.width / 2 - tooltip.offsetWidth / 2}px`;
      tooltip.style.top = `${scrollY + rect.top - tooltip.offsetHeight - 10}px`;

      // Wait until tooltip renders to adjust final horizontal alignment
      requestAnimationFrame(() => {
        tooltip.style.left = `${scrollX + rect.left + rect.width / 2 - tooltip.offsetWidth / 2}px`;
      });
    });

    cell.addEventListener("mouseleave", () => {
      tooltip.style.opacity = "0";
      tooltip.style.display = "none";
      tooltip.style.visibility = "hidden";

      //setTimeout(() => { tooltip.style.display = "none"; }, 200);
    });
  });
});

