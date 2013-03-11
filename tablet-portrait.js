var page = require('webpage').create(),
    system = require('system'),
    address, size;

    address = system.args[1];

    console.log("Rendering tablet portrait...");

    page.viewportSize = {
        width: 768,
        height: 480
    };

    page.open(address, function (status) {
        if (status !== "success") {
            console.log("Unable to load " + address);
            phantom.exit();
        } else {
            address = address.replace("http://", "");
            address = address.replace("https://", "");

            page.render("output/tablet-portrait/" + address + ".png");
            console.log("done.");

            phantom.exit();
        }
    });