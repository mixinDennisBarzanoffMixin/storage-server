package com.example.demo.auth;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

//public class CorsConfig {
//    @Bean
//    public WebMvcConfigurer corsConfigurer()
//    {
//        return new WebMvcConfigurer() {
//            @Override
//            public void addCorsMappings(CorsRegistry registry) {
//                registry.addMapping("/**").allowedOrigins("*");
//                registry.addMapping("/**").exposedHeaders("*");
//                registry.addMapping("/**").allowedMethods("*");
//            }
//        };
//    }
//}

//@Configuration
//public class CorsConfig extends WebMvcConfigurationSupport {
//
//    /* (non-Javadoc)
//     * @see org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport#addCorsMappings(org.springframework.web.servlet.config.annotation.CorsRegistry)
//     */
//    @Override
//    protected void addCorsMappings(CorsRegistry registry) {
//        System.out.println("ADDING CORS CONFIG");
//        //NOTE: servlet context set in "application.properties" is "/api" and request like "/api/session/login" resolves here to "/session/login"!
//        registry.addMapping("/**")
//                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
//                .allowedOrigins("*")
//                .allowedHeaders("*");
////                .allowCredentials(false);
//    }
//}
