<?php
header("Access-Control-Allow-Origin: *");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    $sql = "SELECT * FROM categories ORDER BY name";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    if ($result->num_rows > 0) {
        while ($r = mysqli_fetch_assoc($result)) {
            array_push($data, $r);
        }
        $arr = ["result" => "success", "data" => $data];
    } else {
        $arr = ["result" => "error", "message" => "no categories found"];
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);
?>