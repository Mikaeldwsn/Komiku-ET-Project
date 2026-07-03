<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // $title dan $user_id didapat dari extract()

    $sql = "INSERT INTO comics(title, poster_url, user_id) VALUES(?, '', ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $title, $user_id);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        $arr = ["result" => "success", "comic_id" => $conn->insert_id];
    } else {
        $arr = ["result" => "fail", "message" => $conn->error];
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);
?>