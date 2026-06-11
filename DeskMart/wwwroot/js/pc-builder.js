(function () {
    const SLOT_NAMES = ["CPU", "Motherboard", "RAM", "GPU", "SSD", "PSU", "Case", "Cooler"];

    let componentData = {};
    const selectedComponents = {};
    let buildSummary = {
        totalPrice: 0,
        estimatedPowerWatts: 0,
        recommendedPsuWatts: 0,
        compatibilityWarnings: [],
        stockWarnings: []
    };

    const analyzeBtn = document.getElementById("pcBuilderAnalyzeBtn");
    const loadingEl = document.getElementById("pcBuilderLoading");
    const productsLoadingEl = document.getElementById("pcBuilderProductsLoading");
    const productsErrorEl = document.getElementById("pcBuilderProductsError");
    const analysisResultEl = document.getElementById("pcBuilderAnalysisResult");
    const analysisCardEl = document.getElementById("pcBuilderAnalysisCard");
    const analysisContentEl = analysisCardEl
        ? analysisCardEl.querySelector(".pc-builder-analysis-content")
        : null;

    function formatVnd(amount) {
        return amount.toLocaleString("en-US") + " VND";
    }

    function getStockBadgeClass(stockStatus) {
        switch (stockStatus) {
            case "In Stock":
                return "text-bg-success";
            case "Low Stock":
                return "text-bg-warning";
            case "Out of Stock":
                return "text-bg-danger";
            default:
                return "text-bg-secondary";
        }
    }

    function normalizeProduct(apiProduct) {
        return {
            productId: apiProduct.productId,
            productName: apiProduct.name,
            category: apiProduct.category,
            brand: apiProduct.brand || "",
            price: apiProduct.price,
            stockQuantity: apiProduct.stockQuantity,
            stockStatus: apiProduct.stockStatus,
            keySpecs: apiProduct.keySpecs || "",
            socket: apiProduct.socket || null,
            ramType: apiProduct.ramType || null,
            powerWatts: apiProduct.powerWatts || 0,
            wattage: apiProduct.wattage || null,
            formFactor: apiProduct.formFactor || null,
            gpuClearance: apiProduct.gpuClearance || null
        };
    }

    function createEmptyComponentData() {
        const data = {};
        SLOT_NAMES.forEach(function (slotName) {
            data[slotName] = [];
        });
        return data;
    }

    function getProductById(slotName, productId) {
        const products = componentData[slotName] || [];
        return products.find(function (product) {
            return String(product.productId) === String(productId);
        });
    }

    function setProductsLoading(isLoading) {
        if (productsLoadingEl) {
            productsLoadingEl.classList.toggle("d-none", !isLoading);
        }
    }

    function showProductsError(message) {
        if (productsErrorEl) {
            productsErrorEl.textContent = message;
            productsErrorEl.classList.remove("d-none");
        }

        if (analysisResultEl) {
            analysisResultEl.classList.remove("d-none");
        }

        showAnalysisResult(false, message);
    }

    function clearProductsError() {
        if (productsErrorEl) {
            productsErrorEl.textContent = "";
            productsErrorEl.classList.add("d-none");
        }
    }

    function populateDropdowns() {
        document.querySelectorAll(".pc-builder-slot-select").forEach(function (select) {
            const slotName = select.getAttribute("data-slot");
            const products = componentData[slotName] || [];

            while (select.options.length > 1) {
                select.remove(1);
            }

            products.forEach(function (product) {
                const option = document.createElement("option");
                option.value = String(product.productId);
                option.textContent = product.productName + " — " + formatVnd(product.price);
                select.appendChild(option);
            });

            if (!select.dataset.listenerAttached) {
                select.addEventListener("change", function () {
                    onSlotSelectionChange(slotName, select.value);
                });
                select.dataset.listenerAttached = "true";
            }

            select.disabled = products.length === 0;
        });
    }

    function onSlotSelectionChange(slotName, productId) {
        if (!productId) {
            delete selectedComponents[slotName];
        } else {
            const product = getProductById(slotName, productId);
            if (product) {
                selectedComponents[slotName] = product;
            } else {
                delete selectedComponents[slotName];
            }
        }

        renderSlotInfo(slotName);
        calculateBuildSummary();
        renderSummary();
    }

    function renderSlotInfo(slotName) {
        const infoEl = document.querySelector('[data-slot-info="' + slotName + '"]');
        if (!infoEl) {
            return;
        }

        const product = selectedComponents[slotName];
        if (!product) {
            infoEl.innerHTML = '<span class="text-muted">No component selected.</span>';
            return;
        }

        infoEl.innerHTML =
            '<div class="d-flex justify-content-between align-items-start mb-2">' +
            '<strong class="text-dark">' + escapeHtml(product.productName) + '</strong>' +
            '<span class="badge ' + getStockBadgeClass(product.stockStatus) + '">' +
            escapeHtml(product.stockStatus) +
            "</span></div>" +
            '<div class="mb-1"><span class="text-muted">Price:</span> ' +
            formatVnd(product.price) +
            "</div>" +
            '<div><span class="text-muted">Key specs:</span> ' +
            escapeHtml(product.keySpecs) +
            "</div>";
    }

    function renderAllSlotInfo() {
        SLOT_NAMES.forEach(function (slotName) {
            renderSlotInfo(slotName);
        });
    }

    function calculateBuildSummary() {
        const components = Object.values(selectedComponents);
        const baselineWatts = 80;

        let componentPower = 0;
        let totalPrice = 0;

        components.forEach(function (product) {
            totalPrice += product.price || 0;
            componentPower += product.powerWatts || 0;
        });

        const estimatedPowerWatts = baselineWatts + componentPower;
        const recommendedPsuWatts = Math.ceil((estimatedPowerWatts * 1.3) / 50) * 50;

        const compatibilityWarnings = [];
        const stockWarnings = [];

        const cpu = selectedComponents.CPU;
        const motherboard = selectedComponents.Motherboard;
        const ram = selectedComponents.RAM;
        const psu = selectedComponents.PSU;

        if (cpu && motherboard && cpu.socket && motherboard.socket && cpu.socket !== motherboard.socket) {
            compatibilityWarnings.push(
                "CPU socket (" + cpu.socket + ") does not match motherboard socket (" + motherboard.socket + ")."
            );
        }

        if (ram && motherboard && ram.ramType && motherboard.ramType && ram.ramType !== motherboard.ramType) {
            compatibilityWarnings.push(
                "RAM type (" + ram.ramType + ") does not match motherboard RAM support (" + motherboard.ramType + ")."
            );
        }

        if (psu && psu.wattage && psu.wattage < recommendedPsuWatts) {
            compatibilityWarnings.push(
                "Selected PSU (" + psu.wattage + "W) is below the recommended " + recommendedPsuWatts + "W."
            );
        }

        components.forEach(function (product) {
            if (product.stockQuantity <= 0 || product.stockStatus === "Out of Stock") {
                stockWarnings.push({
                    productId: product.productId,
                    productName: product.productName,
                    message: product.productName + " is out of stock.",
                    severity: "High"
                });
            } else if (product.stockStatus === "Low Stock") {
                stockWarnings.push({
                    productId: product.productId,
                    productName: product.productName,
                    message: product.productName + " has low stock (" + product.stockQuantity + " left).",
                    severity: "Medium"
                });
            }
        });

        buildSummary = {
            totalPrice: totalPrice,
            estimatedPowerWatts: estimatedPowerWatts,
            recommendedPsuWatts: recommendedPsuWatts,
            compatibilityWarnings: compatibilityWarnings,
            stockWarnings: stockWarnings
        };
    }

    function renderSummary() {
        const totalPriceEl = document.getElementById("pcBuilderTotalPrice");
        const estimatedPowerEl = document.getElementById("pcBuilderEstimatedPower");
        const recommendedPsuEl = document.getElementById("pcBuilderRecommendedPsu");
        const compatibilityEl = document.getElementById("pcBuilderCompatibilityWarnings");
        const stockEl = document.getElementById("pcBuilderStockWarnings");

        if (totalPriceEl) {
            totalPriceEl.textContent = formatVnd(buildSummary.totalPrice);
        }

        if (estimatedPowerEl) {
            estimatedPowerEl.textContent = buildSummary.estimatedPowerWatts + " W";
        }

        if (recommendedPsuEl) {
            recommendedPsuEl.textContent = buildSummary.recommendedPsuWatts + " W";
        }

        if (compatibilityEl) {
            if (buildSummary.compatibilityWarnings.length === 0) {
                compatibilityEl.innerHTML = '<li class="text-muted">None</li>';
            } else {
                compatibilityEl.innerHTML = buildSummary.compatibilityWarnings
                    .map(function (warning) {
                        return (
                            '<li class="text-warning-emphasis mb-1">' +
                            '<span class="badge text-bg-warning me-1">Warning</span>' +
                            escapeHtml(warning) +
                            "</li>"
                        );
                    })
                    .join("");
            }
        }

        if (stockEl) {
            if (buildSummary.stockWarnings.length === 0) {
                stockEl.innerHTML = '<li class="text-muted">None</li>';
            } else {
                stockEl.innerHTML = buildSummary.stockWarnings
                    .map(function (warning) {
                        const badgeClass =
                            warning.severity === "High" ? "text-bg-danger" : "text-bg-warning";
                        return (
                            '<li class="mb-1">' +
                            '<span class="badge ' + badgeClass + ' me-1">' +
                            escapeHtml(warning.severity) +
                            "</span>" +
                            escapeHtml(warning.message) +
                            "</li>"
                        );
                    })
                    .join("");
            }
        }

        if (analyzeBtn) {
            analyzeBtn.disabled = Object.keys(selectedComponents).length === 0;
        }
    }

    function buildAnalyzeRequestBody() {
        const components = Object.keys(selectedComponents).map(function (slotName) {
            const product = selectedComponents[slotName];
            return {
                slotName: slotName,
                productId: product.productId,
                productName: product.productName,
                category: product.category,
                price: product.price,
                stockQuantity: product.stockQuantity,
                stockStatus: product.stockStatus,
                keySpecs: product.keySpecs
            };
        });

        return {
            components: components,
            totalPrice: buildSummary.totalPrice,
            compatibilityWarnings: buildSummary.compatibilityWarnings,
            stockWarnings: buildSummary.stockWarnings,
            estimatedPowerWatts: buildSummary.estimatedPowerWatts,
            recommendedPsuWatts: buildSummary.recommendedPsuWatts
        };
    }

    function setAnalyzing(isLoading) {
        if (analyzeBtn) {
            analyzeBtn.disabled = isLoading || Object.keys(selectedComponents).length === 0;
        }

        document.querySelectorAll(".pc-builder-slot-select").forEach(function (select) {
            if (!select.disabled || !isLoading) {
                select.disabled = isLoading || (componentData[select.getAttribute("data-slot")] || []).length === 0;
            }
        });

        if (loadingEl) {
            loadingEl.classList.toggle("d-none", !isLoading);
        }
    }

    function showAnalysisResult(success, analysis) {
        if (!analysisResultEl || !analysisCardEl || !analysisContentEl) {
            return;
        }

        analysisResultEl.classList.remove("d-none");
        analysisCardEl.classList.remove("border-danger", "bg-danger-subtle", "border-success", "bg-success-subtle");

        if (success) {
            analysisCardEl.classList.add("border-success", "bg-success-subtle");
            analysisContentEl.textContent = analysis;
        } else {
            analysisCardEl.classList.add("border-danger", "bg-danger-subtle");
            analysisContentEl.textContent = analysis;
        }
    }

    async function analyzeWithAi() {
        if (Object.keys(selectedComponents).length === 0) {
            showAnalysisResult(false, "Please select at least one PC component before asking AI to analyze the build.");
            return;
        }

        calculateBuildSummary();
        setAnalyzing(true);

        try {
            const response = await fetch("/PcBuilder/AnalyzeWithAi", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Accept: "application/json"
                },
                body: JSON.stringify(buildAnalyzeRequestBody())
            });

            if (!response.ok) {
                throw new Error("Request failed with status " + response.status);
            }

            const data = await response.json();
            showAnalysisResult(data.success, data.analysis || "No analysis received.");
        } catch (error) {
            console.error("PC Builder analyze request failed:", error);
            showAnalysisResult(
                false,
                "DeskMart AI Build Analyst is currently unavailable. Please try again later."
            );
        } finally {
            setAnalyzing(false);
        }
    }

    async function loadProductsFromApi() {
        setProductsLoading(true);
        clearProductsError();
        componentData = createEmptyComponentData();

        try {
            const response = await fetch("/PcBuilder/GetProductsForBuilder", {
                headers: {
                    Accept: "application/json"
                }
            });

            if (!response.ok) {
                throw new Error("Request failed with status " + response.status);
            }

            const data = await response.json();
            if (!data.success || !data.productsBySlot) {
                throw new Error(data.message || "Unable to load PC Builder products.");
            }

            SLOT_NAMES.forEach(function (slotName) {
                const slotProducts = data.productsBySlot[slotName] || [];
                componentData[slotName] = slotProducts.map(normalizeProduct);
            });

            populateDropdowns();
            renderAllSlotInfo();
            calculateBuildSummary();
            renderSummary();
        } catch (error) {
            console.error("PC Builder product load failed:", error);
            showProductsError("Unable to load PC Builder products. Please refresh the page or try again later.");
        } finally {
            setProductsLoading(false);
        }
    }

    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    function init() {
        if (analyzeBtn) {
            analyzeBtn.addEventListener("click", analyzeWithAi);
        }

        loadProductsFromApi();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
