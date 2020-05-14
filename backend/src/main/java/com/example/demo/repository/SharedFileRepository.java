package com.example.demo.repository;

import com.example.demo.entity.SharedFile;
import com.example.demo.entity.User;
import org.springframework.data.repository.CrudRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface SharedFileRepository extends CrudRepository<SharedFile, Long> {
    SharedFile findByFilePathAndUser(String filePath, User user);
    List<SharedFile> findAllByUser(User user);
    SharedFile findByToken(String token);
    @Transactional
    void deleteByToken(String token);
    boolean existsByToken(String token);
}