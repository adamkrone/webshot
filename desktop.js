var page = require('webpage').create(),
    system = require('system'),
    address, size;

    address = system.args[1];

    console.log("Rendering desktop...");

    page.viewportSize = {
        width: 1024,
        height: 768
    };

    page.open(address, function (status) {
        if (status !== "success") {
            console.log("Unable to load " + address);
            phantom.exit();
        } else {
            address = address.replace("http://", "");
            address = address.replace("https://", "");

            page.render("output/desktop/" + address + ".png");
            console.log("done.");

            phantom.exit();
        }
    });