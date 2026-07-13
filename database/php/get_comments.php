<?php
//ngambil semua data komentar
header("Access-Control-Allow-Origin: *");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // $comic_id

    $sql = "SELECT cm.id, cm.comment_text, cm.parent_comment_id, cm.created_at,
                   u.id AS user_id, u.username
            FROM comments cm
            JOIN users u ON cm.user_id = u.id
            WHERE cm.comic_id = ?
            ORDER BY cm.created_at ASC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $comic_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($r = mysqli_fetch_assoc($result)) {
        array_push($data, $r);
    }
    $arr = ["result" => "success", "data" => $data];

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);
?>