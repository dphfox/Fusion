try {
	function parseHeadings() {
		let parsed = [];
		for(element of document.querySelectorAll(".md-main .md-content .md-typeset h2")) {
			parsed.push({
				textLowercase: element.firstChild.textContent.toLowerCase(),
				element: element
			})
		}
		return parsed;
	}
	const headings = parseHeadings();

	function getMatchingHeadings(input) {
		const lowercaseInput = input.toLowerCase();
		let matches = [];
		for(heading of headings) {
			if(lowercaseInput.includes(heading.textLowercase)) {
				matches.push(heading);
			}
		}
		return matches;
	}

	const pasteBox = document.querySelector("#fusiondoc-error-paste-box");

	pasteBox.addEventListener("input", () => {
		let newText = pasteBox.value;
		let matches = getMatchingHeadings(newText);

		let match = matches.length == 1 ? matches[0] : null;

		for(heading of headings) {
			let container = heading.element.parentElement;
			if(match == null || match == heading) {
				container.classList.remove("fusiondoc-error-api-section-defocus");
			} else {
				container.classList.add("fusiondoc-error-api-section-defocus");
			}
		}

		if(match != null) {
			let heading = matches[0].element;
			let y = heading.getBoundingClientRect().top - 300;
			window.scrollTo({top: y, left: 0, behavior: "smooth"})
		}
	});

} catch(e) {
	alert("Couldn't instantiate the error paste box - " + e);
}