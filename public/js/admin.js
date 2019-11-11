function confirmRemoval(element) {
    console.log(element)
    var r = confirm("Are you sure you want to remove this.");
    if (r == true) {
        txt = "Deleting";
        // TODO [$5dc9ae158a1d79000781ea45]:
        // Perform deleting of element using sql.

    } else {
        txt = "Aborted";
    }
}