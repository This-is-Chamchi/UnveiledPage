using UnityEngine;
using UnityEngine.Animations.Rigging;

public class PlayerWeapon_Rigging : MonoBehaviour   {
    #region inspector
    protected MultiParentConstraint m_WeaponRef_Constraint;
    [HideInInspector]public TwoBoneIKConstraint m_WeaponIKSet;
    protected Transform m_IKTarget;
    protected Vector3 m_RayOrigin;
    protected GameObject m_Player;

//===========================================================================//

    [Range(0,3)][SerializeField] protected float m_Ray_Y_Offset = 1f;
    [Range(1,5)][SerializeField] protected float m_Ray_Distance = 2f;
    [Range(0,0.5f)][SerializeField] protected float m_Planted_Y_Offset = 0.17f;

//===========================================================================//
[Space(20)]
    [SerializeField] private LayerMask m_GroundMask;
 
 #endregion

    protected void Awake()  {
        m_WeaponRef_Constraint = GameObject.Find("WeaponRef").GetComponent<MultiParentConstraint>();
        m_WeaponIKSet = GameObject.Find("WeaponIK").GetComponent<TwoBoneIKConstraint>();
        m_IKTarget = GameObject.Find("WeaponTarget").GetComponent<Transform>();
        m_Player = GameObject.FindWithTag("Player");
    }

    protected void Start(){m_WeaponRef_Constraint.weight = 1;}

    protected void LateUpdate() {
        if( m_Player.GetComponent<PlayerController>().state == PlayerState.IdleState ||  
        m_Player.GetComponent<PlayerController>().state == PlayerState.WalkState )
            SetRayWithWeapon();
        else
            m_WeaponIKSet.weight = 0;
    }

    protected void SetRayWithWeapon() {
        m_WeaponIKSet.weight = 0;
        transform.position = m_WeaponRef_Constraint.transform.position;
        m_RayOrigin = transform.position + Vector3.up * m_Ray_Y_Offset;
        var WeaponPos = m_WeaponRef_Constraint.transform.position;
 
        if (Physics.Raycast(m_RayOrigin, Vector3.down, out var Hit, m_Ray_Distance, m_GroundMask))  {
            var HitPosY = Hit.point.y + m_Planted_Y_Offset;
            if (WeaponPos.y != HitPosY) {
                m_WeaponIKSet.weight = 1;
                var Pos = Hit.point;
                Pos.y += m_Planted_Y_Offset;
                m_IKTarget.position = Pos;
                var TargetRot = Quaternion.FromToRotation(Vector3.up, Hit.normal) * m_WeaponRef_Constraint.transform.rotation;
                m_IKTarget.rotation = TargetRot;
            }
        }
        Debug.DrawRay(m_RayOrigin, Vector3.down * m_Ray_Distance, Color.magenta);
    }
}