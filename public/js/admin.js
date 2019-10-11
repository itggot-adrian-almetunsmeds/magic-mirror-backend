function confirmRemoval(element) {
    console.log(element)
    var r = confirm("Are you sure you want to remove this.");
    if (r == true) {
        txt = "Deleting";
        // Perform deleting of element using sql.

    } else {
        txt = "Aborted";
    }
}