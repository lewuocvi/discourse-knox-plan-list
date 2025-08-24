import { apiInitializer } from "discourse/lib/api";

function stringToHex(str) {
    return [...str].map(char => char.charCodeAt(0).toString(16).padStart(2, '0')).join('');
}

// Hàm lấy tên gói và giá
function extractPackageInfo(packageString) {
    // Sử dụng regex để tách tên gói và giá
    let regex = /(.+?)\s*–\s*(\d+)(K)/;
    let match = packageString.match(regex);

    if (match) {
        // Lấy tên gói và giá với đơn vị K
        let packageName = match[1].trim();
        let priceInK = parseInt(match[2]); // Lấy giá trị 150
        let price = priceInK * 1000; // Chuyển từ K sang giá trị thực tế

        return { packageName, price };
    } else {
        return null; // Nếu không tìm thấy thông tin
    }
}

const preloadedData = JSON.parse(document.getElementById("data-preloaded").getAttribute("data-preloaded"));
const { username } = JSON.parse(preloadedData.currentUser || "{ }");

export default apiInitializer((api) => {
    //
    function handleAdClick({ data_title, data_text, data_url }) {
        Swal.fire({
            title: data_title,
            text: data_text,
            imageUrl: data_url,
            imageWidth: 400,
            showConfirmButton: false,
            customClass: {
                container: "quick-response-code-container",
                popup: "quick-response-code-popup",
                header: "quick-response-code-header",
                title: 'quick-response-code-title',
                closeButton: 'quick-response-code-close-button',
                image: 'quick-response-code-image',
                htmlContainer: 'quick-response-code-text',
                confirmButton: 'quick-response-code-confirm-bitton',
                denyButton: 'quick-response-code-deny-button',
                cancelButton: 'quick-response-code-cancel-button',
                footer: 'quick-response-code-footer'
            }
        });
    }

    const observer = new MutationObserver((mutations) => {
        for (const mutation of mutations) {
            for (const node of mutation.addedNodes) {
                if (node.nodeType === Node.ELEMENT_NODE) {
                    if (node.classList && node.classList.contains("knox-plan-link")) {
                        node.onclick = ((event) => {
                            event.preventDefault(); // Ngăn không cho chuyển hướng
                            const data = node.getAttribute('data-package'); // Lấy tên gói từ data attribute
                            if (!username) {
                                return document.querySelector(".login-button").click();
                            }
                            //
                            const data_text = "Quét mã này để mua gói dịch vụ tự động.";
                            const { price } = extractPackageInfo(data);
                            const data_title = data;
                            const code = stringToHex(username);
                            const data_url = `https://api.vietqr.io/image/970422-24767896789-v6xr1xZ.jpg?accountName=LE%20QUOC%20VI&amount=${price}&addInfo=NAP${code}END`;
                            handleAdClick({ data_title, data_text, data_url });
                        });
                    }
                }
            }
        }
    });

    observer.observe(document.body, { childList: true, subtree: true });
});
