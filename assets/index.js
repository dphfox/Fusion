// hack; if the body is scrolled, manually activate the header background
const header = document.querySelector("[data-md-color-primary=black] .md-header")
function updateScroll() {
	if(document.body.scrollTop > 10) {
		header.dataset.mdState = "shadow";
	} else {
		header.dataset.mdState = "";
	}
}

updateScroll();
document.body.addEventListener("scroll", updateScroll);