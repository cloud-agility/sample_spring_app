package com.example.demo.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Value;

@RestController
public class MainController {

  private static final Logger logger = LoggerFactory
      .getLogger(MainController.class);

  @Value("${serviceVersion}")
  private String serviceVersion;

  @RequestMapping(value = "/hello")
  public String index() {
    logger.info("hello endpoint was hit");
    return "Hello World from version " + serviceVersion + "!";
  }

}
