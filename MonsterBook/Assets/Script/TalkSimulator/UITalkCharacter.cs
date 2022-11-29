using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UITalkCharacter : MonoBehaviour
{
    [SerializeField]
    private string characterName;

    [SerializeField]
    private UIBaseImage characterImage;

    [SerializeField]
    private UITweenAnimator showAnimator;

    [SerializeField]
    private UITweenAnimator hideAnimator;

    [SerializeField]
    private bool isShow = false;
    public bool IsShow { get { return isShow; } }

    public string GetCharacterName()
    {
        return characterName;
    }

    public void ChangeCharacter(string characterName, Sprite characterSprite)
    {
        this.characterName = characterName;
        characterImage.SetImage(characterSprite);
    }

    public void Show()
    {
        isShow = true;
        showAnimator.PlayAnimation();
    }

    public void Hide()
    {
        isShow = false;
        hideAnimator.PlayAnimation();
    }


}
