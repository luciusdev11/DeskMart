(function () {
    const chatEl = document.getElementById("aiAdvisorChat");
    const inputEl = document.getElementById("aiAdvisorInput");
    const submitBtn = document.getElementById("aiAdvisorSubmit");
    const loadingEl = document.getElementById("aiAdvisorLoading");
    const alertEl = document.getElementById("aiAdvisorAlert");
    const emptyStateEl = document.getElementById("aiAdvisorEmptyState");
    const chipButtons = document.querySelectorAll(".ai-advisor-chip");

    if (!chatEl || !inputEl || !submitBtn) {
        return;
    }

    function hideAlert() {
        alertEl.classList.add("d-none");
        alertEl.textContent = "";
    }

    function showAlert(message) {
        alertEl.textContent = message;
        alertEl.classList.remove("d-none");
    }

    function setLoading(isLoading) {
        submitBtn.disabled = isLoading;
        chipButtons.forEach(function (chip) {
            chip.disabled = isLoading;
        });
        loadingEl.classList.toggle("d-none", !isLoading);
    }

    function appendMessage(role, text) {
        if (emptyStateEl) {
            emptyStateEl.remove();
        }

        const wrapper = document.createElement("div");
        wrapper.className = "ai-advisor-message mb-3 " + (role === "user" ? "text-end" : "text-start");

        const bubble = document.createElement("div");
        bubble.className =
            "d-inline-block text-start px-3 py-2 rounded-3 shadow-sm " +
            (role === "user" ? "bg-primary text-white" : "bg-white border");

        const label = document.createElement("div");
        label.className = "small fw-semibold mb-1 " + (role === "user" ? "text-white-50" : "text-muted");
        label.textContent = role === "user" ? "You" : "DeskMart AI Advisor";

        const content = document.createElement("div");
        content.className = "ai-advisor-message-content";
        content.textContent = text;

        bubble.appendChild(label);
        bubble.appendChild(content);
        wrapper.appendChild(bubble);
        chatEl.appendChild(wrapper);
        chatEl.scrollTop = chatEl.scrollHeight;
    }

    async function sendMessage(message) {
        const trimmed = message.trim();
        if (!trimmed) {
            showAlert("Please enter a question for DeskMart AI Advisor.");
            inputEl.focus();
            return;
        }

        hideAlert();
        appendMessage("user", trimmed);
        inputEl.value = "";
        setLoading(true);

        try {
            const response = await fetch("/AiAdvisor/Ask", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                body: JSON.stringify({ message: trimmed })
            });

            if (!response.ok) {
                throw new Error("Request failed with status " + response.status);
            }

            const data = await response.json();

            if (!data.success) {
                showAlert(data.reply || "DeskMart AI Advisor could not process your request.");
                return;
            }

            appendMessage("assistant", data.reply || "No reply received.");
        } catch (error) {
            console.error("AI Advisor request failed:", error);
            showAlert("DeskMart AI Advisor is currently unavailable. Please try again later.");
        } finally {
            setLoading(false);
            inputEl.focus();
        }
    }

    submitBtn.addEventListener("click", function () {
        sendMessage(inputEl.value);
    });

    inputEl.addEventListener("keydown", function (event) {
        if (event.key === "Enter" && !event.shiftKey) {
            event.preventDefault();
            sendMessage(inputEl.value);
        }
    });

    chipButtons.forEach(function (chip) {
        chip.addEventListener("click", function () {
            const prompt = chip.getAttribute("data-prompt") || "";
            inputEl.value = prompt;
            sendMessage(prompt);
        });
    });
})();
