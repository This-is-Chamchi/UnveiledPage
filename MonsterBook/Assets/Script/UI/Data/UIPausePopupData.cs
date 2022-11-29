using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class UIPausePopupData : UIPopupData
{
    public UnityAction endCloseAction;

    public UIPausePopupData()
    {
        viewName = "Pause";
    }

}
