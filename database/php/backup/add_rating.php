<?php
// insert rating baru, atau update kalau user sudah pernah rating komik ini berdasarkan id

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // $comic_id, $user_id, $rating_value (1-5)

    $sql = "INSERT INTO ratings(comic_id, user_id, rating_value)
            VALUES(?, ?, ?)
            ON DUPLICATE KEY UPDATE rating_value = VALUES(rating_value)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("iii", $comic_id, $user_id, $rating_value);
    $stmt->execute();

    // Ambil rata-rata rating terbaru untuk dikirim balik ke Flutter
    $avgSql = "SELECT AVG(rating_value) AS avg_rating FROM ratings WHERE comic_id = ?";
    $avgStmt = $conn->prepare($avgSql);
    $avgStmt->bind_param("i", $comic_id);
    $avgStmt->execute();
    $avgResult = $avgStmt->get_result();
    $avgRow = mysqli_fetch_assoc($avgResult);

    $arr = [
        "result" => "success",
        "average_rating" => round(floatval($avgRow['avg_rating']), 1),
    ];

    $stmt->close();
    $avgStmt->close();
    $conn->close();
}

echo json_encode($arr);
?>