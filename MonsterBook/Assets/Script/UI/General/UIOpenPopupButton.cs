using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Game.UI;

public class UIOpenPopupButton : MonoBehaviour
{
    public string popupName;

    public void Open()
    {
        Game.UI.UIController.Instance.OpenPopup(popupName);
    }


}
