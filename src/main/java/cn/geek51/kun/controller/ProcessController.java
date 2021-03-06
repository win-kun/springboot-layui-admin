package cn.geek51.kun.controller;


import cn.geek51.kun.entity.Process;
import cn.geek51.kun.entity.ProcessDto;
import cn.geek51.kun.entity.WorkOrder;
import cn.geek51.kun.mapper.ProcessMapper;
import cn.geek51.kun.mapper.WorkOrderMapper;
import cn.geek51.kun.service.ProcessService;
import cn.geek51.util.ResponseUtil;
import cn.geek51.util.UuidUtil;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author kun
 * @since 2020-07-15
 */
@RestController
public class ProcessController {

    @Autowired
    private ProcessService processService;

    @Autowired
    private ProcessMapper processMapper;

    @Autowired
    private WorkOrderMapper workOrderMapper;

    //查询
    @GetMapping("/processs")
    public Object list(Integer page,Integer limit,String query) throws Exception {

        HashMap queryMap = new HashMap();
        // 进行拼接, 拼接成一个MAP查询
        if (query != null) {
            queryMap = new ObjectMapper().readValue(query, HashMap.class);
        }

        IPage<Process> processIPage = processService.findList(page, limit, queryMap);
        HashMap<Object, Object> map = new HashMap<>();
        map.put("size",processIPage.getTotal());
        return ResponseUtil.general_response(processIPage.getRecords(),map);
    }

    // 新建
    @PostMapping("/processs")
    public Object insertProcess(@RequestBody JSONObject params) {
        String departUuid = params.getString("departUuid");
        String productUuid = params.getString("productUuid");
        JSONArray jsonArray = params.getJSONArray("processDtoList");
        List<ProcessDto> processDtoList = jsonArray.toJavaList(ProcessDto.class);
        for (ProcessDto processDto : processDtoList) {
            Process process = processMapper.findProcess(departUuid, productUuid, processDto.getProcessNumber());
            if (process != null){
                return ResponseUtil.general_response(405,"工序已存在");
            }
            processDto.setProcessUuid(UuidUtil.getUuid());
        }
        System.out.println(departUuid);
        System.out.println(productUuid);
        processDtoList.forEach(System.out::println);

        int i = processService.insertBatch(departUuid, productUuid, processDtoList);
        return ResponseUtil.general_response(i);
    }

    // 更改
    @PutMapping("/processs")
    @Transactional
    public Object updateProcess(@RequestBody Process process) {

        Process tempProcess = processMapper.selectById(process.getId());

        if (!process.getPrice().equals(tempProcess.getPrice())){
            int i = workOrderMapper.updateMoney(tempProcess.getDepartUuid(),tempProcess.getProductUuid(),tempProcess.getProcessNumber(),process.getPrice());
        }

        boolean b = processService.updateById(process);
        if (b) {
            return ResponseUtil.general_response("success update department!");
        } else {
            return ResponseUtil.general_response(ResponseUtil.CODE_EXCEPTION,"更新失败");
        }
    }

    // 删除
    @DeleteMapping("/processs/{id}")
    public Object deleteProcess(@PathVariable("id") Integer id) {
        processService.removeById(id);
        return ResponseUtil.general_response("success delete department!");
    }

    // 批量删除
    @DeleteMapping("/processs")
    public Object deleteProcessBatch(@RequestBody JSONObject params) {
        JSONArray ids = params.getJSONArray("ids");
        List<String> idList = ids.toJavaList(String.class);
        boolean b = processService.removeByIds(idList);
        if (b) {
            return ResponseUtil.general_response("success delete department!");
        } else {
            return ResponseUtil.general_response(ResponseUtil.CODE_EXCEPTION,"删除失败");
        }
    }
}

