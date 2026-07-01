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

    @GetMapping({"/workspace-not-found", "/page-not-found", "/access-denied", "/wrong-access"})
    public String invalidAccess() {
        return "forward:/invalid-access.html";
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

    @GetMapping("/w/{companyCode}/parts")
    public String parts() {
        return "forward:/parts.html";
    }

    @GetMapping("/w/{companyCode}/part-units")
    public String partUnits() {
        return "forward:/part-units.html";
    }

    @GetMapping("/w/{companyCode}/users")
    public String users() {
        return "forward:/users.html";
    }

    @GetMapping("/w/{companyCode}/mypage")
    public String mypage() {
        return "forward:/mypage.html";
    }

    @GetMapping("/w/{companyCode}/history/stock")
    public String historyStock() {
        return "forward:/history-stock.html";
    }

    @GetMapping("/w/{companyCode}/history/inspection")
    public String historyInspection() {
        return "forward:/history-inspection.html";
    }

    @GetMapping("/w/{companyCode}/inbound")
    public String inbound() {
        return "forward:/inbound.html";
    }

    @GetMapping("/w/{companyCode}/inbound/new")
    public String inboundRegister() {
        return "forward:/inbound-register.html";
    }

    @GetMapping("/w/{companyCode}/outbound")
    public String outbound() {
        return "forward:/outbound.html";
    }

    @GetMapping("/w/{companyCode}/outbound/new")
    public String outboundRegister() {
        return "forward:/outbound-register.html";
    }

    @GetMapping("/w/{companyCode}/inspection")
    public String inspection() {
        return "forward:/inspection.html";
    }

    @GetMapping("/w/{companyCode}/inspection/templates")
    public String inspectionTemplates() {
        return "forward:/inspection-templates.html";
    }

    @GetMapping("/w/{companyCode}/{*path}")
    public String unknownWorkspacePage() {
        return "forward:/invalid-access.html";
    }
}
