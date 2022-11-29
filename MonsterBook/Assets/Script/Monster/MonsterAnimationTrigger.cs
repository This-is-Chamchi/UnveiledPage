using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MonsterAnimationTrigger : MonoBehaviour
{

    private bool isAnimationEnd;
    private bool isEvent;
    private bool isEffectEvent;
    private bool isAttackEvent;

    public bool gisAnimationEnd { get => isAnimationEnd; set { isAttackEvent = value; } }



    private int CurrentIndex;




    public bool gEffectEvent
    {
        get
        {
            bool Temp = isEffectEvent;
            isEffectEvent = false;
            return Temp;
        }
    }

    public bool gisEvent
    {
        get
        {
            bool Temp = isEvent;
            isEvent = false;
            return Temp;
        }

    }
    
    public bool gisAttackEvent
    {
        get
        {
            bool Temp = isAttackEvent;
        
            return Temp;
        }
    }
    public void init()
    {
        isAnimationEnd = false;
        isEvent = false;
        isEffectEvent = false;
        
        
    }

    private void EffectEvent()
    {
        isEffectEvent = true;
    }
    private void AnimStart()
    {

        isAnimationEnd = false;
        isEvent = false;
    }

    private void AnimEnd()
    {
        isAnimationEnd = true;
    }
    private void AnimEvent()
    {
        isEvent = true;
    }

}
