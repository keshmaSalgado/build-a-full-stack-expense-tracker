package com.expensetracker.service;

import com.expensetracker.dto.CategoryResponse;
import com.expensetracker.dto.TransactionResponse;
import com.expensetracker.dto.UserResponse;
import com.expensetracker.entity.Category;
import com.expensetracker.entity.Transaction;
import com.expensetracker.entity.User;
import com.expensetracker.repository.CategoryRepository;
import org.springframework.stereotype.Service;

@Service
public class MapperService {
    private final CategoryRepository categoryRepository;

    public MapperService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public UserResponse toUserResponse(User user) {
        return new UserResponse(user.getId(), user.getName(), user.getEmail(), user.getProfilePictureUrl(), user.getCurrency());
    }

    public CategoryResponse toCategoryResponse(Category category) {
        return new CategoryResponse(category.getId(), category.getName(), category.getColor());
    }

    public TransactionResponse toTransactionResponse(Transaction transaction) {
        Category category = categoryRepository.findById(transaction.getCategoryId())
                .orElse(new Category("Unknown", "#64748b", transaction.getUserId()));
        return new TransactionResponse(
                transaction.getId(),
                transaction.getTitle(),
                transaction.getDescription(),
                transaction.getAmount(),
                transaction.getDate(),
                transaction.getType(),
                toCategoryResponse(category)
        );
    }
}
