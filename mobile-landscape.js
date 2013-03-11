var page = require('webpage').create(),
    system = require('system'),
    address, size;

    address = system.args[1];

    console.log("Rendering mobile landscape...");

    page.viewportSize = {
        width: 480,
        height: 320
    };

    page.open(address, function (status) {
        if (status !== "success") {
            console.log("Unable to load " + address);
            phantom.exit();
        } else {
            address = address.replace("http://", "");
            address = address.replace("https://", "");

            page.render("output/mobile-landscape/" + address + ".png");
            console.log("done.");

            phantom.exit();
        }
    });