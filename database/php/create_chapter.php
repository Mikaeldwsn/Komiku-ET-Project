<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // $comic_id, $chapter_number, $title (bisa "Chapter 1")

    $sql = "INSERT INTO chapters(comic_id, chapter_number, title) VALUES(?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("iis", $comic_id, $chapter_number, $title);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        $arr = ["result" => "success", "chapter_id" => $conn->insert_id];
    } else {
        $arr = ["result" => "fail", "message" => $conn->error];
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);
?>