 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class GamificationManager {
    
    public static final Integer SIGN_UP_ENERGIZERS = 100;
    public static final Integer HARD_TASK_ENERGIZERS = 500;
    public static final Integer MEDIUM_TASK_ENERGIZERS = 300;
    public static final Integer EASY_TASK_ENERGIZERS = 100;
    public static final Integer DEDUCTION_ON_HARD_REOPEN = 100;
    public static final Integer DEDUCTION_ON_MEDIUM_REOPEN = 30;
    public static final Integer DEDUCTION_ON_EASY_REOPEN = 10;
    public static final Integer DEDUCTION_ON_COMPLETION_POST_DUE_HARD = 100;
    public static final Integer DEDUCTION_ON_COMPLETION_POST_DUE_MEDIUM = 30;
    public static final Integer DEDUCTION_ON_COMPLETION_POST_DUE_EASY = 10; 
    public static final Integer MEDALS_ON_COMPLETION = 1;
    
    /** This function return's amount of Energizers to add to user while sign up **/
    public static Integer addEnergizersForSignUp(){
        return SIGN_UP_ENERGIZERS;
    }
    
    /** This function return's amount of Energizers to be deducted on reopen of task **/
    public static Integer deductEnergizersForReopen(String taskLevel, Integer currentEnergizers){
        if(currentEnergizers == null){
            return 0;
        }else if(taskLevel == 'Easy'){
            return currentEnergizers - DEDUCTION_ON_EASY_REOPEN;
        }else if(taskLevel == 'Medium'){
            return currentEnergizers - DEDUCTION_ON_MEDIUM_REOPEN;
        }else if(taskLevel == 'Hard'){
            return currentEnergizers - DEDUCTION_ON_HARD_REOPEN;
        }else{
            return currentEnergizers;   
        }
    }
    
    /** This function return's amount of energizers user has earned **/
    public static Integer getEarnedEnergizers(String taskLevel,Boolean deductionForReopen, Boolean deductionForOverdue){
        Integer earnedEnergizers = 0;
        if(taskLevel == 'Easy'){
            earnedEnergizers = EASY_TASK_ENERGIZERS;
            if(deductionForReopen)
                earnedEnergizers -= DEDUCTION_ON_EASY_REOPEN;
            if(deductionForOverdue)
                earnedEnergizers -= DEDUCTION_ON_COMPLETION_POST_DUE_EASY;
        }else if(taskLevel == 'Medium'){
            earnedEnergizers = MEDIUM_TASK_ENERGIZERS;
            if(deductionForReopen)
                earnedEnergizers -= DEDUCTION_ON_MEDIUM_REOPEN;
            if(deductionForOverdue)
                earnedEnergizers -= DEDUCTION_ON_COMPLETION_POST_DUE_MEDIUM;
        }else if(taskLevel == 'Hard'){
            earnedEnergizers = HARD_TASK_ENERGIZERS;
            if(deductionForReopen)
                earnedEnergizers -= DEDUCTION_ON_HARD_REOPEN;
            if(deductionForOverdue)
                earnedEnergizers -= DEDUCTION_ON_COMPLETION_POST_DUE_HARD;
        }
        return earnedEnergizers;
    }
    
    /** This function return's amount of medals user has earned **/
    public static Integer getEarnedMedals(){
        return MEDALS_ON_COMPLETION;
    }
}