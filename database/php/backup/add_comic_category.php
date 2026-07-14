<?php
// add_comic_category.php
// Menyimpan 1 pasangan comic_id - category_id ke tabel comic_category.
// Dipanggil berulang (loop) dari Flutter, sekali per kategori yang dipilih user.
// Pola sama dengan addmoviegenre.php di Week 11.

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");
if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // $comic_id, $category_id

    $sql = "INSERT INTO comic_category(comic_id, category_id) VALUES(?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $comic_id, $category_id);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        $arr = ["result" => "success"];
    } else {
        $arr = ["result" => "fail", "message" => $conn->error];
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);
?>