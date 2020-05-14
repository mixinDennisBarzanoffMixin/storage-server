package com.example.demo.controller

import com.example.demo.entity.SharedFile
import com.example.demo.repository.SharedFileRepository
import com.example.demo.repository.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpEntity
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.io.File
import java.nio.file.Path

class FileData(val name: String, val lastModified: Long, val isDirectory: Boolean) {
    var isShared = false
}

val workingDir = System.getProperty("user.dir")

//@Transactional
@RestController
@RequestMapping(path = ["/files"])
open class FileController @Autowired constructor(
        private val sharedFileRepository: SharedFileRepository,
        private val userRepository: UserRepository
) {
    @GetMapping
    fun getFileNamesAtDirectory(@RequestParam directoryName: String, authentication: Authentication): HttpEntity<List<FileData>> {
        val directory = getFile(directoryName, authentication)
        val filesInDirectory = directory.listFiles() ?: return ResponseEntity.notFound().build()
        filesInDirectory.map {
            val user = userRepository.findByEmail(authentication.name)
            if (sharedFileRepository.findByFilePathAndUser("${directoryName}/${it.path.substringAfterLast('/')}", user) != null) {
                val newFile = FileData(name = it.name, isDirectory = true, lastModified = it.lastModified())
                newFile.isShared = true
            }
        }
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

    @PostMapping("/share")
    fun shareFile(@RequestParam filePath: String, authentication: Authentication): ResponseEntity<*> {
        val file = getFile(filePath, authentication)
        val user = userRepository.findByEmail(authentication.name)
        return if (file.exists()) {
            val existingSharedFile = sharedFileRepository.findByFilePathAndUser(filePath, user)
            if (existingSharedFile != null) {
                return ResponseEntity.ok(existingSharedFile.token)
            }
            val sharedFile = SharedFile(filePath, user)
            this.sharedFileRepository.save(sharedFile)
            ResponseEntity.ok(sharedFile.token.toString())
        } else {
            ResponseEntity.status(HttpStatus.CONFLICT).body("File does not exist")
        }
    }

    @GetMapping("/getAllShared")
    fun getAllShared(authentication: Authentication): ResponseEntity<*> {
        val user = userRepository.findByEmail(authentication.name)
        val files = sharedFileRepository.findAllByUser(user)
        val systemFiles = files.map { getFile(it.filePath, it.user.email) }
        return ResponseEntity.ok(systemFiles.map { FileData(name = it.name, isDirectory = it.isDirectory, lastModified = it.lastModified()) })
    }

    @GetMapping("/getSharedFile")
    fun getSharedFile(@RequestParam token: String, authentication: Authentication): ResponseEntity<*> {
        val file = sharedFileRepository.findByToken(token)
        return if (file != null) {
            val systemFile = getFile(file.filePath, file.user.email)
//            val fileData = systemFile.toFileData()
            ResponseEntity.ok(systemFile.toFileData())
        } else {
            ResponseEntity.status(HttpStatus.CONFLICT).body("Token incorrect")
        }
    }

    //    @Transactional
    @PostMapping("/stopSharing")
    open fun stopSharing(@RequestParam token: String, authentication: Authentication): ResponseEntity<*> {
        val exists = sharedFileRepository.existsByToken(token)
        return if (exists) {
            sharedFileRepository.deleteByToken(token)
            ResponseEntity.ok().build<String>()
        } else ResponseEntity.status(HttpStatus.NOT_FOUND).body("No file found by token")

    }

    @PostMapping("/upload", consumes = ["multipart/form-data"])
    fun upload(@RequestParam directoryName: String, @RequestParam file: MultipartFile, authentication: Authentication): ResponseEntity<Unit> {
        return try {
            val newFile = getFile("$directoryName${file.originalFilename}", authentication)
            file.transferTo(newFile)
            ResponseEntity.ok().build()
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.CONFLICT).build()
        }
    }

    private fun getFile(filePath: String, authentication: Authentication) =
            File("$workingDir/databaseFiles/${authentication.name}$filePath")

    private fun getFile(filePath: String, email: String) =
            File("$workingDir/databaseFiles/${email}$filePath")
}

fun File.toFileData(): FileData {
    return FileData(name = name, isDirectory = isDirectory, lastModified = lastModified())
}
