package com.pcs.web.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;

class PageControllerTest {

    private final PageController controller = new PageController();

    @Test
    void documentsPageForwardsToUnifiedDocumentPage() {
        assertEquals("forward:/documents.html", controller.documents());
    }

    @Test
    void inboundManagementRouteRedirectsToUnifiedDocumentPage() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/w/pcs/inbound");
        request.setQueryString("keyword=IN-20260630");

        String viewName = controller.inbound("pcs", request);

        assertEquals("redirect:/w/pcs/documents?documentType=INBOUND&keyword=IN-20260630", viewName);
    }

    @Test
    void outboundManagementRouteRedirectsToUnifiedDocumentPage() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/w/pcs/outbound");
        request.setQueryString("keyword=OUT-20260630");

        String viewName = controller.outbound("pcs", request);

        assertEquals("redirect:/w/pcs/documents?documentType=OUTBOUND&keyword=OUT-20260630", viewName);
    }

    @Test
    void legacyRouteRedirectKeepsRequestedTypeWhenDuplicateDocumentTypeExists() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/w/pcs/outbound");
        request.setQueryString("documentType=INBOUND&keyword=OUT-20260630&page=2");

        String viewName = controller.outbound("pcs", request);

        assertEquals("redirect:/w/pcs/documents?documentType=OUTBOUND&keyword=OUT-20260630&page=2", viewName);
    }
}
