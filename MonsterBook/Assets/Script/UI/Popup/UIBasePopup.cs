using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using Game.UI;

public abstract class UIBasePopup : UIBaseView
{

    public bool useBackground = true;

    protected override void Start()
    {

    }

    [Button("Open")]
    public override void Open()
    {
        base.Open();
    }

    [Button("Close")]
    public override void Close()
    {
        Game.UI.UIController.Instance.ClosePopup(this);
    }

    public override void EndClose()
    {
        Destroy(this.gameObject);
    }

}
