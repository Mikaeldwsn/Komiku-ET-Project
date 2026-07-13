<?php
// incrementing/menambah view_count komik sebanyak 1 setiap kali Halaman Baca Komik dibuka.

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // $comic_id

    $sql = "UPDATE comics SET view_count = view_count + 1 WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $comic_id);
    $stmt->execute();

    $arr = ["result" => "success"];

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);
?>