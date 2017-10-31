package com.example.demo;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.beans.factory.annotation.Autowired;
import static org.junit.Assert.*;

import com.example.demo.controller.MainController;

@RunWith(SpringRunner.class)
@SpringBootTest
public class DemoApplicationTests {

	@Autowired
	private MainController mainController;

	@Test
	public void testHelloMethodNotNullReturn() {
    	assertNotNull(this.mainController.index());
	}

	@Test
	public void testHelloMethodNotEmptyReturn() {
    	assertFalse(this.mainController.index().isEmpty());
	}

}
