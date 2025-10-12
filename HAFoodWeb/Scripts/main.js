// SLIDESHOW
let slides = document.querySelectorAll(".slide");
let index = 0;
setInterval(() => {
    slides[index].classList.remove("active");
    index = (index + 1) % slides.length;
    slides[index].classList.add("active");
}, 5000);

// SEARCH DROPDOWN
const openBtn = document.getElementById("openSearch");
const dropdown = document.getElementById("searchDropdown");
const overlay = document.getElementById("pageOverlay");
if (openBtn) {
    openBtn.addEventListener("click", () => {
        const isVisible = dropdown.style.display === "flex";
        dropdown.style.display = isVisible ? "none" : "flex";
        overlay.style.display = isVisible ? "none" : "block";
        if (!isVisible) dropdown.querySelector("input").focus();
    });
}
if (overlay) {
    overlay.addEventListener("click", () => {
        dropdown.style.display = "none";
        overlay.style.display = "none";
        const userDropdown = document.getElementById("userDropdown");
        if (userDropdown) userDropdown.style.display = "none";
    });
}

// USER DROPDOWN
const userIcon = document.getElementById("userIcon");
const userDropdown = document.getElementById("userDropdown");
if (userIcon && userDropdown) {
    userIcon.addEventListener("click", (e) => {
        e.stopPropagation();
        userDropdown.style.display = userDropdown.style.display === "flex" ? "none" : "flex";
    });
    document.addEventListener("click", (e) => {
        if (!userDropdown.contains(e.target) && e.target !== userIcon) {
            userDropdown.style.display = "none";
        }
    });
}