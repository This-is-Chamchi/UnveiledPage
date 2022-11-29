using UnityEngine;

public class UIController : MonoBehaviour
{
    public float SP_Cur = 0.0f;
    public bool SP_Using = false;
    private float SP_UpSpeed = 15.0f;

    private PlayerAction action;

    #region notouch
    [SerializeField] private Transform m_HpParent;
    private UnityEngine.UI.Image[] m_HpImage;
    [SerializeField] private Transform m_SpParent;
    private UnityEngine.UI.Image m_SpImage;
    [SerializeField] private RectTransform wireAim;
    #endregion

    private void Awake()
    {

        action = new PlayerAction();
        action.UI.Esc.started += val => OnPause();
        action.Enable();

        m_HpImage = new UnityEngine.UI.Image[m_HpParent.childCount];
        m_SpImage = m_SpParent.GetComponent<UnityEngine.UI.Image>();

        for (int i = 0; i < m_HpImage.Length; i++)
        {
            m_HpImage[i] = m_HpParent.GetChild(i).GetComponent<UnityEngine.UI.Image>();
        }
    }

    protected void Update()
    {
        if (!SP_Using)
        {
            if (SP_Cur < 100.0f)
            {
                SP_Cur += SP_UpSpeed * Time.deltaTime;
                m_SpImage.fillAmount = SP_Cur / 100;
            }
            else return;
        }
        else return;
    }

    public void SetHP(int hp)
    {
        for (int i = 0; i < m_HpImage.Length; i++)
        {
            m_HpImage[i].fillAmount = 1;
            m_HpImage[i].enabled = false;
        }

        var count = hp / 10;
        for (int i = 0; i < count; i++)
        {
            m_HpImage[i].enabled = true;
        }
    }

    public void SetSp(float sp)
    {
        SP_Cur = sp;
        m_SpImage.fillAmount = SP_Cur / 100;
    }

    public void SP_Drain(float sp)
    {
        if (SP_Cur >= 100 * sp / 100)
        {
            SP_Using = true;

            SP_Cur -= sp;
            m_SpImage.fillAmount = SP_Cur / 100;
        }
    }

    public void SetWireAim(Vector3 pos = default(Vector3), bool active = false)
    {
        wireAim.gameObject.SetActive(active);
        wireAim.position = Camera.main.WorldToScreenPoint(pos);
    }

    protected void OnPause()
    {
        Game.UI.UIController.Instance.OpenPopup(new UIPausePopupData()
        {
            endCloseAction = () =>
            {
                action.Enable();
            }
        });
        action.Disable();
    }

    private void OnDisable()
    {
        action.Disable();
    }

}
