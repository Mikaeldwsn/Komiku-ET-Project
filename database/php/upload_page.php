<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

extract($_POST);
// $chapter_id, $page_number, $image (base64 string)

function savePageImage($base64Image, $chapterId) {
    $response = ["result" => "error", "message" => ""];

    $imageData = base64_decode($base64Image);
    if ($imageData === false) {
        $response["message"] = "Failed to decode Base64 image.";
        return $response;
    }

    $directory = "images/pages/" . htmlspecialchars($chapterId);
    if (!is_dir($directory)) {
        if (!mkdir($directory, 0777, true)) {
            $response["message"] = "Failed to create directory.";
            return $response;
        }
    }

    $timestamp = time();
    $filename = $timestamp . ".png";
    $filePath = $directory . "/" . $filename;

    if (file_put_contents($filePath, $imageData) === false) {
        $response["message"] = "Failed to save the file.";
        return $response;
    }

    $response["result"] = "success";
    $response["file_path"] = $filePath;
    return $response;
}

$saveResult = savePageImage($image, $chapter_id);

if ($saveResult["result"] == "success") {
    $conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");
    if (!$conn->connect_error) {
        $filePath = $saveResult["file_path"];
        $sql = "INSERT INTO pages(chapter_id, page_number, image_url) VALUES(?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iis", $chapter_id, $page_number, $filePath);
        $stmt->execute();
        $saveResult["page_id"] = $conn->insert_id;
        $stmt->close();
        $conn->close();
    }
}

echo json_encode($saveResult);
?>