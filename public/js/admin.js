function confirmRemoval(element) {
    console.log(element)
    var r = confirm("Are you sure you want to remove this.");
    if (r == true) {
        txt = "Deleting";
        // TODO [$5dc8716b6a66ed00071445e1]:
        // Perform deleting of element using sql.

    } else {
        txt = "Aborted";
    }
}