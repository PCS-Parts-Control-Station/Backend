package com.pcs.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PageController {

    @GetMapping({"/", "/main"})
    public String main() {
        return "forward:/main.html";
    }
}
