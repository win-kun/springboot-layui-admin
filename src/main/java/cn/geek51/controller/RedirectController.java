package cn.geek51.controller;

import cn.geek51.domain.Department;
import cn.geek51.domain.Position;
import cn.geek51.domain.UserAuth;
import cn.geek51.service.IDepartmentService;
import cn.geek51.service.IPositionService;
import cn.geek51.kun.entity.Depart;
import cn.geek51.kun.entity.Product;
import cn.geek51.kun.service.DepartService;
import cn.geek51.kun.service.ProductService;
import cn.geek51.util.UserContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

/**
 * 页面转发控制器
 */
@Controller
public class RedirectController {
    @Autowired
    IPositionService positionService;

    @Autowired
    IDepartmentService departmentService;

    @Autowired
    DepartService departService;

    @Autowired
    ProductService productService;

    @GetMapping("/login")
    public String toLogin() {
        return "user/login";
    }

    @GetMapping("/register")
    public String toRegister() {
        return "user/register";
    }

    @GetMapping("/employee")
    public String toEmployee(Model model) {
        List<Position> positionList = positionService.listAll();
        List<Department> departmentList = departmentService.listAll();
        model.addAttribute("positionList", positionList);
        model.addAttribute("departmentList", departmentList);
        return "employee_view";
    }

    @GetMapping("/newEmployee")
    public String toNewEmployee(Model model) {
        /*List<Position> positionList = positionService.listAll();*/
        List<Depart> departList = departService.list();
        /*model.addAttribute("positionList", positionList);*/
        model.addAttribute("departList", departList);
        return "new_employee_view";
    }

    @GetMapping("/layers/employee/insert")
    public String toEmployeeInsert(Model model) {
        List<Position> positionList = positionService.listAll();
        List<Department> departmentList = departmentService.listAll();
        model.addAttribute("positionList", positionList);
        model.addAttribute("departmentList", departmentList);
        return "layers/employee_insert";
    }

    @GetMapping("/post")
    public String toPost(Model model) {
        UserAuth user = UserContext.getCurrentUser();
        model.addAttribute("user", user);
        return "post_view";
    }

    @GetMapping("/download")
    public String toDownload(Model model) {
        UserAuth user = UserContext.getCurrentUser();
        model.addAttribute("user", user);
        return "download_view";
    }

    @GetMapping("/department")
    public String toDepartment() {
        return "department_view";
    }

    @GetMapping("/depart")
    public String toDepart() {
        return "depart_view";
    }

    @GetMapping("/product")
    public String toProduct() {
        return "product_view";
    }

    @GetMapping("/process")
    public String toProcess(Model model) {
        List<Depart> departList = departService.list();
        List<Product> productList = productService.list();
        model.addAttribute("departList",departList);
        model.addAttribute("productList",productList);
        return "process_view";
    }

    @GetMapping("/workOrder")
    public String toWorkOrder(Model model) {
        List<Depart> departList = departService.list();
        List<Product> productList = productService.list();
        model.addAttribute("departList",departList);
        model.addAttribute("productList",productList);
        return "workOrder_view";
    }


    @GetMapping("/workOrderInsert")
    public String workOrderInsert() {
        return "workOrder-insert_view";
    }
    @GetMapping("/employeeSalary")
    public String toEmployeeSalary(Model model) {
        List<Depart> departList = departService.list();
        List<Product> productList = productService.list();
        model.addAttribute("departList",departList);
        model.addAttribute("productList",productList);
        return "employeeSalary_view";
    }

    @GetMapping("/productSalary")
    public String toProductSalary(Model model) {
      /*  List<Depart> departList = departService.list();
        List<Product> productList = productService.list();
        model.addAttribute("departList",departList);
        model.addAttribute("productList",productList);*/
        return "productSalary_view";
    }


    @GetMapping("/auth")
    public String toAuth() {
        return "auth_view";
    }

    @GetMapping("/position")
    public String toPosition() {
        return "position_view";
    }

    @GetMapping("/index")
    public String toIndex(Model model) {
        UserAuth user = UserContext.getCurrentUser();
        model.addAttribute("user", user);
        return "index_view";
    }

    @GetMapping("/")
    public String toMain(Model model) {
        UserAuth user = UserContext.getCurrentUser();
        model.addAttribute("user", user);
        return "index_view";
    }
}
