package com.expensetracker.service;

import com.expensetracker.dto.AuthResponse;
import com.expensetracker.dto.LoginRequest;
import com.expensetracker.dto.RegisterRequest;
import com.expensetracker.entity.Category;
import com.expensetracker.entity.User;
import com.expensetracker.exception.ApiException;
import com.expensetracker.repository.CategoryRepository;
import com.expensetracker.repository.UserRepository;
import com.expensetracker.security.JwtService;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AuthService {
    private static final List<String> DEFAULT_CATEGORIES = List.of(
            "Food", "Transport", "Shopping", "Bills", "Entertainment", "Health", "Education"
    );

    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final MapperService mapperService;

    public AuthService(UserRepository userRepository, CategoryRepository categoryRepository, PasswordEncoder passwordEncoder,
                       AuthenticationManager authenticationManager, JwtService jwtService, MapperService mapperService) {
        this.userRepository = userRepository;
        this.categoryRepository = categoryRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.mapperService = mapperService;
    }

    public AuthResponse register(RegisterRequest request) {
        if (!request.password().equals(request.confirmPassword())) {
            throw new ApiException("Passwords do not match", HttpStatus.BAD_REQUEST);
        }
        String email = request.email().toLowerCase();
        if (userRepository.existsByEmail(email)) {
            throw new ApiException("Email is already registered", HttpStatus.CONFLICT);
        }

        User user = new User(request.name(), email, passwordEncoder.encode(request.password()));
        User savedUser = userRepository.save(user);
        DEFAULT_CATEGORIES.forEach(name -> categoryRepository.save(new Category(name, defaultColor(name), savedUser.getId())));
        return new AuthResponse(jwtService.generateToken(savedUser), mapperService.toUserResponse(savedUser));
    }

    public AuthResponse login(LoginRequest request) {
        String email = request.email().toLowerCase();
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(email, request.password()));
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException("Invalid credentials", HttpStatus.UNAUTHORIZED));
        return new AuthResponse(jwtService.generateToken(user), mapperService.toUserResponse(user));
    }

    private String defaultColor(String name) {
        return switch (name) {
            case "Food" -> "#22c55e";
            case "Transport" -> "#0ea5e9";
            case "Shopping" -> "#f97316";
            case "Bills" -> "#ef4444";
            case "Entertainment" -> "#a855f7";
            case "Health" -> "#14b8a6";
            default -> "#64748b";
        };
    }
}
