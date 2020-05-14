package com.example.demo.entity;

import javax.persistence.*;
import java.util.UUID;

@Entity
public class SharedFile {
    private String filePath;
    @ManyToOne(targetEntity = User.class)
    private User user;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(unique = true)
    private String token = UUID.randomUUID().toString();

    public String getToken() {
        return token;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public SharedFile() {
    }

    public SharedFile(String filePath, User user) {
        this.filePath = filePath;
        this.user = user;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }
}
