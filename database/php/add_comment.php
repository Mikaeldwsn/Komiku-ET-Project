<?php
// utk insert comment baru

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // Kalau parent_comment_id kosong = komentar utama, bukan reply
    $parentId = (isset($parent_comment_id) && $parent_comment_id !== '')
        ? intval($parent_comment_id)
        : null;

    if ($parentId === null) {
        $sql = "INSERT INTO comments(comic_id, user_id, comment_text) VALUES(?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iis", $comic_id, $user_id, $comment_text);
    } else {
        $sql = "INSERT INTO comments(comic_id, user_id, parent_comment_id, comment_text) VALUES(?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iiis", $comic_id, $user_id, $parentId, $comment_text);
    }

    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        $arr = ["result" => "success", "comment_id" => $conn->insert_id];
    } else {
        $arr = ["result" => "fail", "message" => $conn->error];
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);
?>