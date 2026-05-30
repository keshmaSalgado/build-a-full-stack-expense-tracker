package com.expensetracker.service;

import com.expensetracker.dto.UpdateUserRequest;
import com.expensetracker.dto.UserResponse;
import com.expensetracker.entity.User;
import com.expensetracker.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final MapperService mapperService;

    public UserService(UserRepository userRepository, MapperService mapperService) {
        this.userRepository = userRepository;
        this.mapperService = mapperService;
    }

    public UserResponse me(User user) {
        return mapperService.toUserResponse(user);
    }

    public UserResponse update(User user, UpdateUserRequest request) {
        user.setName(request.name());
        user.setCurrency(request.currency());
        user.setProfilePictureUrl(request.profilePictureUrl());
        return mapperService.toUserResponse(userRepository.save(user));
    }
}
