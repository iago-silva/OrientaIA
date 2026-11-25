document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-sidebar-toggle]").forEach(button => {
    button.addEventListener("click", () => {
      const sidebar = document.getElementById("sidebar");
      const open = sidebar.classList.toggle("open");
      button.setAttribute("aria-expanded", String(open));
    });
  });
  document.querySelectorAll("[data-dialog]").forEach(button => {
    button.addEventListener("click", () => {
      const dialog = document.getElementById(button.dataset.dialog);
      if (dialog) dialog.showModal();
    });
  });
  document.querySelectorAll("[data-dialog-close]").forEach(button => {
    button.addEventListener("click", () => button.closest("dialog").close());
  });
  document.querySelectorAll("dialog").forEach(dialog => {
    dialog.addEventListener("click", event => { if (event.target === dialog) dialog.close(); });
  });
  document.querySelectorAll("form[data-check-required]").forEach(form => {
    const button = form.querySelector("[data-submit-checks]");
    const boxes = [...form.querySelectorAll("input[type=checkbox][required]")];
    const refresh = () => {
      if (button) button.disabled = !boxes.every(box => box.checked) || form.dataset.blocked === "true";
    };
    boxes.forEach(box => box.addEventListener("change", refresh));
    refresh();
  });
  document.querySelectorAll("[data-file-input]").forEach(input => {
    const label = document.querySelector("[data-file-name]");
    input.addEventListener("change", () => {
      if (label) label.textContent = input.files[0]?.name || "Nenhum documento selecionado";
    });
    const dropZone = input.closest(".upload-drop");
    if (dropZone) {
      dropZone.addEventListener("dragover", event => {
        event.preventDefault();
        dropZone.classList.add("drag-over");
      });
      dropZone.addEventListener("dragleave", () => dropZone.classList.remove("drag-over"));
      dropZone.addEventListener("drop", event => {
        event.preventDefault();
        dropZone.classList.remove("drag-over");
        const file = event.dataTransfer?.files[0];
        if (!file) return;
        const transfer = new DataTransfer();
        transfer.items.add(file);
        input.files = transfer.files;
        input.dispatchEvent(new Event("change", { bubbles: true }));
      });
    }
  });
});
