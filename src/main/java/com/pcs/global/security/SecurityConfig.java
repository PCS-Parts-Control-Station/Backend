package com.pcs.global.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final StaffPermissionAuthorizationFilter staffPermissionAuthorizationFilter;
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtAccessDeniedHandler jwtAccessDeniedHandler;

    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthenticationFilter,
            StaffPermissionAuthorizationFilter staffPermissionAuthorizationFilter,
            JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint,
            JwtAccessDeniedHandler jwtAccessDeniedHandler
    ) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
        this.staffPermissionAuthorizationFilter = staffPermissionAuthorizationFilter;
        this.jwtAuthenticationEntryPoint = jwtAuthenticationEntryPoint;
        this.jwtAccessDeniedHandler = jwtAccessDeniedHandler;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .logout(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint(jwtAuthenticationEntryPoint)
                        .accessDeniedHandler(jwtAccessDeniedHandler)
                )
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(
                                "/swagger-ui.html",
                                "/swagger-ui/**",
                                "/v3/api-docs",
                                "/v3/api-docs/**",
                                "/v3/api-docs.yaml"
                        ).permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/owners/signup").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/owners/login").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/workspaces/*/public-info").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/workspaces/login").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/workspaces/*/login").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/auth/refresh").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/auth/logout").permitAll()
                        .requestMatchers("/api/owners/**").hasRole(PcsRoleGroups.OWNER)
                        .requestMatchers("/api/workspaces/*/users/**").hasAnyRole(PcsRoleGroups.USER_MANAGERS)
                        .requestMatchers("/api/workspaces/*/company/**").hasRole(PcsRoleGroups.OWNER)
                        .requestMatchers("/api/workspaces/*/companies/**").hasRole(PcsRoleGroups.OWNER)
                        .requestMatchers("/api/workspaces/*/**").hasAnyRole(PcsRoleGroups.WORKSPACE_USERS)
                        .requestMatchers("/api/**").authenticated()
                        .anyRequest().permitAll()
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterAfter(staffPermissionAuthorizationFilter, JwtAuthenticationFilter.class)
                .build();
    }
}
