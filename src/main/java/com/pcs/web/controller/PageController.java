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

    @GetMapping({"/w", "/w/", "/w/{companyCode}"})
    public String workspaceLogin() {
        return "forward:/workspace-login.html";
    }

    @GetMapping("/w/{companyCode}/dashboard")
    public String dashboard() {
        return "forward:/dashboard.html";
    }

    @GetMapping("/w/{companyCode}/categories")
    public String categories() {
        return "forward:/categories.html";
    }

    @GetMapping("/w/{companyCode}/partners")
    public String partners() {
        return "forward:/partners.html";
    }

    @GetMapping("/w/{companyCode}/inbound")
    public String inbound() {
        return "forward:/inbound.html";
    }

    @GetMapping("/w/{companyCode}/inbound/new")
    public String inboundRegister() {
        return "forward:/inbound-register.html";
    }
}
