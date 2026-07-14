<?php
// fungsinya mengambil semua halaman komik untuk ditampilkan di Baca Komik.
header("Access-Control-Allow-Origin: *");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    extract($_POST);
    // $comic_id

    $sql = "SELECT p.id, p.page_number, p.image_url, c.chapter_number
            FROM pages p
            JOIN chapters c ON p.chapter_id = c.id
            WHERE c.comic_id = ?
            ORDER BY c.chapter_number ASC, p.page_number ASC";
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