package com.example.demo.entity;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
public class User {
    public User() {
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "user_id")
    private long userId;

    private String email;

    private String password;

    private String name;

    private boolean isEnabled;

    public long getUserId() {
        return userId;
    }

    // awful boilerplate

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean isEnabled() {
        return isEnabled;
    }

    public void setEnabled(boolean enabled) {
        isEnabled = enabled;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", email='" + email + '\'' +
                ", password='" + password + '\'' +
                ", name='" + name + '\'' +
                ", isEnabled=" + isEnabled +
                '}';
    }

    @OneToOne(targetEntity = ConfirmationToken.class)
    private ConfirmationToken token;

    @OneToMany(targetEntity = SharedFile.class)
    @JoinColumn(name = "user_id")
    private List<SharedFile> sharedFileList = new ArrayList<>();
}