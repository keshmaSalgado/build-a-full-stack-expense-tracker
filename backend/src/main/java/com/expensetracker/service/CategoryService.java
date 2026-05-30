package com.expensetracker.service;

import com.expensetracker.dto.CategoryRequest;
import com.expensetracker.dto.CategoryResponse;
import com.expensetracker.entity.Category;
import com.expensetracker.entity.User;
import com.expensetracker.exception.ApiException;
import com.expensetracker.repository.CategoryRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {
    private final CategoryRepository categoryRepository;
    private final MapperService mapperService;

    public CategoryService(CategoryRepository categoryRepository, MapperService mapperService) {
        this.categoryRepository = categoryRepository;
        this.mapperService = mapperService;
    }

    public List<CategoryResponse> findAll(User user) {
        return categoryRepository.findByUserIdOrderByNameAsc(user.getId()).stream().map(mapperService::toCategoryResponse).toList();
    }

    public CategoryResponse create(User user, CategoryRequest request) {
        if (categoryRepository.existsByNameIgnoreCaseAndUserId(request.name(), user.getId())) {
            throw new ApiException("Category already exists", HttpStatus.CONFLICT);
        }
        Category category = new Category(request.name(), request.color(), user.getId());
        return mapperService.toCategoryResponse(categoryRepository.save(category));
    }

    public CategoryResponse update(User user, String id, CategoryRequest request) {
        Category category = getOwnedCategory(user, id);
        category.setName(request.name());
        category.setColor(request.color());
        return mapperService.toCategoryResponse(categoryRepository.save(category));
    }

    public void delete(User user, String id) {
        categoryRepository.delete(getOwnedCategory(user, id));
    }

    public Category getOwnedCategory(User user, String id) {
        return categoryRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ApiException("Category not found", HttpStatus.NOT_FOUND));
    }
}
