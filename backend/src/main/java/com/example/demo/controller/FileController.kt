package com.example.demo.controller

import org.springframework.http.HttpEntity
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

import java.io.File

class FileData(val name: String, val lastModified: Long, val isDirectory: Boolean)

val workingDir = System.getProperty("user.dir")

@RestController
@RequestMapping(path = ["/files"])
class FileController {
    @GetMapping
    fun getFileNamesAtDirectory(@RequestParam directoryName: String, authentication: Authentication): HttpEntity<List<FileData>> {
        val directory = getFile(directoryName, authentication)
        val filesInDirectory = directory.listFiles() ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(filesInDirectory.map { FileData(it.name, lastModified = it.lastModified(), isDirectory = it.isDirectory) })
    }

    @PutMapping("/rename")
    fun renameFileAtDirectory(@RequestParam filePath: String, @RequestParam renameTo: String, authentication: Authentication): ResponseEntity<*> {
        val file = getFile(filePath, authentication)

        if (!file.exists()) {
            return ResponseEntity<Unit>(HttpStatus.NOT_FOUND)
        }
        val pathBeforeFile = filePath.substringBefore(file.name)
        val filePathToRename = "$pathBeforeFile/$renameTo"
        val fileToRenameTo = getFile(filePathToRename, authentication)
        file.renameTo(fileToRenameTo)
        return ResponseEntity.ok("Successfully renamed to $filePathToRename")
    }

    @PostMapping("/create")
    fun createFile(@RequestParam filePath: String, @RequestParam isDirectory: Boolean, @RequestBody(required = false) content: String?, authentication: Authentication): ResponseEntity<*> {
        val file = getFile(filePath, authentication)
        return if (isDirectory) {
            if (file.mkdir()) {
                ResponseEntity.status(HttpStatus.OK).body("")
            } else {
                ResponseEntity.status(HttpStatus.CONFLICT).body("Could not create directory")
            }

        } else
            if (file.createNewFile()) {
                file.writeText(content!!)
                ResponseEntity.status(HttpStatus.OK).body("")
            } else {
                ResponseEntity.status(HttpStatus.CONFLICT).body("File already exists")
            }
    }

    @PostMapping("/delete")
    fun deleteFile(@RequestParam filePath: String, authentication: Authentication): ResponseEntity<*> {
        val file = getFile(filePath, authentication)
        return if (file.deleteRecursively()) {
            ResponseEntity.ok("Successfully created file")
        } else ResponseEntity("Could not delete file or directory", HttpStatus.CONFLICT)
    }
    @PostMapping("/move")
    fun moveFile(@RequestParam filePath: String, @RequestParam filePathToMoveTo: String, authentication: Authentication): ResponseEntity<*> {
        val file = getFile(filePath, authentication)
        val fileToMoveTo = getFile(filePathToMoveTo, authentication)
        val successful = file.renameTo(fileToMoveTo)
        return if (successful) {
            ResponseEntity.ok().build<Unit>()
        } else {
            ResponseEntity.status(HttpStatus.CONFLICT).body("Could not move file")
        }
    }

    private fun getFile(filePath: String, authentication: Authentication) =
            File("$workingDir/databaseFiles/${authentication.name}$filePath")
}
