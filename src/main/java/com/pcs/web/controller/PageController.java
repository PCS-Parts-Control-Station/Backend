package com.pcs.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PageController {

    @GetMapping({"/", "/main"})
    public String main() {
        return "forward:/main.html";
    }

    @GetMapping("/company/register")
    public String companyRegister() {
        return "forward:/company-register.html";
    }

    @GetMapping("/w/{companyCode}/categories")
    public String categories() {
        return "forward:/categories.html";
    }
}
