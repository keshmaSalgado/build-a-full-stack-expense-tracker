package com.expensetracker.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "categories")
@CompoundIndex(name = "category_name_user_unique", def = "{'name': 1, 'userId': 1}", unique = true)
public class Category {
    @Id
    private String id;

    private String name;

    private String color;

    private String userId;

    public Category() {
    }

    public Category(String name, String color, String userId) {
        this.name = name;
        this.color = color;
        this.userId = userId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
