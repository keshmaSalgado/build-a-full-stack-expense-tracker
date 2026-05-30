package com.expensetracker.repository;

import com.expensetracker.entity.Category;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository extends MongoRepository<Category, String> {
    List<Category> findByUserIdOrderByNameAsc(String userId);
    Optional<Category> findByIdAndUserId(String id, String userId);
    boolean existsByNameIgnoreCaseAndUserId(String name, String userId);
}
